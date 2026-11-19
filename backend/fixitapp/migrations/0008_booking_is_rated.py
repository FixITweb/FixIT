# Generated migration to add is_rated field to Booking model

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('fixitapp', '0007_remove_booking_customer_phone_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='booking',
            name='is_rated',
            field=models.BooleanField(default=False),
        ),
    ]
